export function TobboLoader({ light = false }: { light?: boolean }) {
  return (
    <div className={light ? "loader loader--light" : "loader"} role="status" aria-label="Loading">
      <span />
      <span />
      <span />
    </div>
  );
}

export function TobboLoadingOverlay() {
  return (
    <div className="overlay">
      <TobboLoader />
    </div>
  );
}
