export const newDate = (): string => {
  const d = new Date();
  return (new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString()).slice(0, -1);
}
