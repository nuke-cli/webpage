<script lang="ts">
	import { classnames } from '@utils';

	export let size: 'sm' | 'md' | 'lg';
	export let bold: boolean = false;
	export let italic: boolean = false;
</script>

<p
	class={classnames('Text', [
		{ class: 'Text--small', condition: size === 'sm' },
		{ class: 'Text--medium', condition: size === 'md' || !size },
		{ class: 'Text--large', condition: size === 'lg' },
		{ class: 'Text--bold', condition: !!bold },
		{ class: 'Text--italic', condition: !!italic },
	])}
>
	<slot />
</p>

<style lang="scss">
	.Text {
		color: inherit;
	}

	.Text--small {
		font-size: 12px;
	}

	.Text--medium {
		font-size: 16px;
	}

	.Text--large {
		font-size: 20px;
	}

	.Text--bold {
		font-weight: bold;
	}

	.Text--italic {
		font-style: italic;
	}
</style>
