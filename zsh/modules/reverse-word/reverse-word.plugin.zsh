reverse-word() {
for f in "$@"; do # reverse word
  echo "${(j::)${(@Oa)${(s::):-$f}}}"
done
}
