export const newDate = (): string => {
  const d = new Date();
  return formatDate(new Date(d.getTime() - d.getTimezoneOffset() * 60000));
};

export const formatDate = (date: Date): string => {
  return date.toISOString().slice(0, -1);
};
