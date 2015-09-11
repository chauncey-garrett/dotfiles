# inspect data files
i() {
  (head -n 5; tail -n 5) < "$1" | column -t
}
