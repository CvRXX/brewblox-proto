export interface SequenceDocArgument {
  name: string;
  desc: string;
  type: string;
}

export interface SequenceDocInstruction {
  name: string;
  desc: string;
  arguments: SequenceDocArgument[];
  errors: string[];
  example: string[];
}

export interface SequenceDoc {
  instructions: SequenceDocInstruction[];
}

declare module './Sequence.json' {
  const doc: SequenceDoc;
  export default doc;
}
