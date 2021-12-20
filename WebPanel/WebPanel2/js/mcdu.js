const MCDU = (function () {
	const screenImageBaseUrl = '/screenshot?canvasindex=10&type=jpg';
	const refreshInterval = 2000;

	const body = document.body;
	let currentCacheBust = 0;
	let lastSentText = '';

	init();

	return {
		toggleUsedUniverse
	}

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

	function init()
	{
		body.dataset.lastTouch = 0;
		body.addEventListener('touchstart', preventZoomAction, { passive: false });

		registerButtons();
		registerKeyboardInput();
		setInterval(refreshScreen, refreshInterval);
		refreshScreen();    
	}

	function refreshScreen() {
		loadScreenImage(screenImageBaseUrl)
			.then(setScreenSrc)
			.catch(setScreenSrc);
	}

	function setScreenSrc(url) {
		url = typeof url === 'string' ? url : '';
		showScreenImageLoadState(url !== '');
		document.querySelectorAll('[data-element="lcdimage"]').forEach((imageElement) => {
			imageElement.src = url;
		});
	}

	function loadScreenImage(baseUrl) {
		currentCacheBust = new Date().getTime();
		return new Promise((resolve, reject) => {
			const url = baseUrl + '?cacheBust=' + currentCacheBust;
			const img = new Image;

			img.addEventListener('error', reject);

			img.addEventListener('load', (event) => {
				showScreenImageLoadState(true);
				resolve(url);
			});
			img.src = url;
		});
	}

	function showScreenImageLoadState(isOK) {
		if (!isOK) {
			console.log('fail');
		}
	}

	function toggleUsedUniverse() {
		body.setAttribute('data-used-universe', body.getAttribute('data-used-universe') === '1' ? '0' : '1');
	}

	function registerButtons() {
		document.querySelectorAll('[data-button]').forEach((buttonElement) => {
			const buttonFunction = getButtonFunction(buttonElement);
			if (!(typeof buttonFunction === 'function')) {
				return;
			}
			buttonElement.addEventListener('click', buttonFunction);
			buttonElement.addEventListener('touchstart', preventZoomAction, true);
		});
	}

	function registerKeyboardInput() {
		const keyTranslation = {
			BACKSPACE: 'CLR'
		};
		body.addEventListener('keyup', (event) => {
			const key = event.key.toUpperCase();
			if (key.match(/^[A-Z0-9/\-+.\ ]$/)) {
				if (key === '+' || key === '-') {
					return sendPlusMinusKey();
				}
				return sendButtonpress('button', key);
			}

			const translatedKey = keyTranslation[key];
			if (translatedKey) {
				return sendButtonpress('button', translatedKey);
			}
		});
	}

	function getButtonFunction(buttonElement) {
		const buttonActions = buttonElement.getAttribute('data-button').split(':');
		const actionKey = buttonActions[0];
		const actionValue = buttonActions[1];

		if(!actionKey) {
			return;
		}

		if (actionKey === 'toggleUsedUniverse') {
			return toggleUsedUniverse;
		}

		if (actionKey === 'button' && actionValue === '-') {
			return sendPlusMinusKey;
		}

		return function () {
			sendButtonpress(actionKey, actionValue);
		};
	}

	function sendPlusMinusKey() {
		if (lastSentText === '-') {
			sendButtonpress('button', 'CLR')
				.then(() => {
					sendButtonpress('button', '+');
				})
			return;
		}

		if (lastSentText === '+') {
			sendButtonpress('button', 'CLR')
				.then(() => {
					sendButtonpress('button', '-');
				})
			return;
		}

		sendButtonpress('button', '-');
	}

	function sendButtonpress(type, text) {
		// console.log({ type, text });
		let request = new XMLHttpRequest;
		request.open("POST", "/run.cgi?value=nasal");
		request.setRequestHeader("Content-Type", "application/json");
		let body = JSON.stringify({
			"name": "",
			"children": [
				{
					"name": "script",
					"index": 0,
					"value": "mcdu." + type + "(\"" + text + "\", 0);"
				}
			]
		});
		request.send(body);
		return new Promise((resolve) => {
			request.addEventListener('load', () => {
				lastSentText = text;
				refreshScreen();
				resolve();
			}, true);
		});
	}

	//https://exceptionshub.com/disable-double-tap-zoom-option-in-browser-on-touch-devices.html
	function preventZoomAction(event) {
		const t2 = event.timeStamp;
		const touchedElement = event.currentTarget;
		const t1 = touchedElement.dataset.lastTouch || t2;
		const dt = t2 - t1;
		const fingers = event.touches.length;
		touchedElement.dataset.lastTouch = t2;

		if (!dt || dt > 500 || fingers > 1) {
			// no double-tap
			return;
		}

		event.preventDefault();
		event.target.click();
	}
})();
