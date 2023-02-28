import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// read the initial store value
const stored = browser ? (localStorage.content || "[]") : "[]";

// create the store
export const content = writable<string>(stored);

content.subscribe((value: string) => {
  if (browser) {
    localStorage.content = value;
  }
});
