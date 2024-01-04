import App from './App.svelte';

const app = new App({
	target: document.body,
	props: {
		label: 'world',
		age: 12,
	}
});

export default app;