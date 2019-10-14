# IDG Contributing Guidelines

These examples will show the IDG Guidelines for contributing. Please follow this at all times, or your contribution will not be merged.

## Basic Guidelines:
- Use Tabs to indent code, DO NOT USE SPACE.
- Use lowerCamelCase or underscores for naming Nasal variables/functions (someFunction, some_function).
- Comments optional for XML, mandatory for Nasal.
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
		setprop("/something", something);
	}, 5);
}
```

## Forks, Branches, and Merging
We do not add contributors outside of IDG, so please fork the repository, and commit your changes there. Branches are optional. When you are ready for IDG to look over you work, submit a pull request, following our pull request template, and an IDG Developer will look over it. If there is an issue that needs to be resolved before merging, the IDG Developer will leave a comment on the pull request.
