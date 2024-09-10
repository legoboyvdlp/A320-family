# A320-family Contributing Guidelines

These examples will show the Guidelines for contributing. Please follow this at all times, or your contribution will not be merged.

## Basic Guidelines:
- Use Tabs to indent code
- Use lowerCamelCase for naming Nasal variables/functions (someFunction)
- Please document your code!
- Do not add a comment to every line, only to functions/groups of code.
- Remove .bak or .blend files, unless absolutely needed.
- Leave one extra line at the bottom of each file.

## Formatting Guidelines:
Indenting and Line Breaks:
```
<!-- XML -->
<something>
	<something-else>0</something-else>
	<something-more>
		<more-stuff></more-stuff>
	</something-more>
</something>
```

```
# Nasal
var something = func {
	somethingElse();
}
```
Brackets, Spaces, Commas, Semi-Colons, and Parentheses:
```
var something = 0;
var someOtherThing = func {
	if (something == 1) {
		something = 0;
	} else {
		something = 1;
	}
	settimer(func {
		setprop("something", something);
	}, 5);
}
```

## Forks, Branches, and Merging
Please fork the repository, and commit your changes there. Branches are optional. When you are ready for us to look over you work, submit a pull request, following our pull request template, and a main Developer will look over it. If there is an issue that needs to be resolved before merging, the Developer will leave a comment on the pull request.

## Editing source files
If you want to edit source files like textures (e.g. via Gimp layers), 3D Models (via Blender scenes) or audio files, please make sure to contact the maintainers first _before_ starting with the work. Otherwise, when you publish directly edited textures/models, your changes would get overwritten when the source files are modified and exported to the final model/texture without your changes incorporated. See also [PR #336](https://github.com/legoboyvdlp/A320-family/pull/336#issuecomment-2339842697).
