export interface StructuredEntity {
  content: string;
  created: Date,
};

export const sortEntities = (x: StructuredEntity, y: StructuredEntity): number => {
  if (x.created < y.created) {
    return -1;
  } else if (x.created > y.created) {
    return 1;
  } else {
    return 0;
  }
};
