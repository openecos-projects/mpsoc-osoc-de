BEGIN {
  replacing = 0
}

/^module PSRAMWrapper\(/ {
  while ((getline line < replacement) > 0)
    print line
  close(replacement)
  replacing = 1
  next
}

replacing && /^endmodule$/ {
  replacing = 0
  next
}

!replacing {
  print
}
