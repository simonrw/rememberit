import { type ClassValue, clsx } from "clsx";
import moment, { Moment } from "moment-timezone";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function momentToDatePicker(date: Moment): string {
  const tz = moment.tz.guess();
  return date.tz(tz).format("YYYY-MM-DDTHH:mm");
}
