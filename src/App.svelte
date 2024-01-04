<script lang="ts">
	export let label: string;
	export let age: number;
</script>

<div class="wrapper">
	<h1>Hello, {label}!</h1>
</div>

<style lang="scss">
	.wrapper {
		width: 100%;
		display: flex;
		align-items: center;
	}

	.wrapper > h1 {
		color: green;
	}
</style>
