type Option = {
	class: string;
	condition: boolean;
};

function classnames(main: string, options: Option[]): string {
	const appliedClasses: string = options.reduce((prev, curr) => {
		return `${prev} ${curr.condition && curr.class}`;
	}, '');

	return `${main} ${appliedClasses}`;
}

export default classnames;
