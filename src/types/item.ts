import { Moment } from "moment";

export interface Item {
  id: string;
  content: string;
  created: Moment;
}
