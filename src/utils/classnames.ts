type Option = {
	class: string;
	condition: boolean;
};

function classnames(main: string, options: Option[]): string {
	const appliedClasses: string[] = options
		.filter((option) => option.condition)
		.map((option) => option.class);

	return [main, ...appliedClasses].join(' ');
}

export default classnames;
