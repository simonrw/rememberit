export const newDate = (): Date => {
  const d = new Date();
  return d;
};

export const formatDate = (date: Date): string => {
  return date.toISOString().slice(0, -1);
};
