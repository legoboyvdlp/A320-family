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
