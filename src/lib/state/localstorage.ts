import { writable } from 'svelte/store';
import { browser } from '$app/environment';

// read the initial store value
let stored = "[]";
if (browser) {
  if (localStorage.content && (localStorage.content !== "undefined")) {
    stored = localStorage.content;
  }
}

// create the store
export const content = writable<string>(stored);

content.subscribe((value: string) => {
  if (browser) {
    localStorage.content = value;
  }
});
