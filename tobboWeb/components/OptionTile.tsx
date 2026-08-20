type OptionTileProps = {
  index: number;
  text: string;
  selected: boolean;
  onSelect: () => void;
};

export function OptionTile({ index, text, selected, onSelect }: OptionTileProps) {
  return (
    <button
      type="button"
      className={selected ? "option is-selected" : "option"}
      onClick={onSelect}
      aria-pressed={selected}
    >
      <span className="option-index">{String(index + 1).padStart(2, "0")}</span>
      <span className="option-text">{text}</span>
    </button>
  );
}
