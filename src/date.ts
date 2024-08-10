import moment from "moment";
import { Moment } from "moment";

export const newDate = (): Moment => {
  return moment();
};

export const formatDate = (date: Moment): string => {
  return date.calendar(); // toISOString().slice(0, -1);
};
