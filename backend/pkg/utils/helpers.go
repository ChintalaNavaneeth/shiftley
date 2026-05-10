package utils

func SafeLast4(s string) string {
	if len(s) <= 4 {
		return s
	}
	return s[len(s)-4:]
}
