package utils

import (
	"fmt"

	"github.com/buger/goterm"
	"github.com/sirupsen/logrus"
)

// GotermHook is a logrus hook to write logrus events to a Goterm box
type GotermHook struct {
	box *goterm.Box
}

// NewGotermHook creates a new Goterm box
func NewGotermHook() (*GotermHook, error) {
	g := &GotermHook{
		box: goterm.NewBox(100|goterm.PCT, 10, 0),
	}

	return g, nil
}

// Fire is a Logrus hook func
func (g *GotermHook) Fire(entry *logrus.Entry) error {
	value, err := entry.String()
	if err != nil {
		return err
	}

	fmt.Fprint(g.box, value)
	goterm.Print(goterm.MoveTo(g.box.String(), 1, 1))
	goterm.Flush()

	return nil
}

// Levels is a Logrus hook event
func (g *GotermHook) Levels() []logrus.Level {
	return []logrus.Level{
		logrus.PanicLevel,
		logrus.FatalLevel,
		logrus.ErrorLevel,
		logrus.WarnLevel,
		logrus.InfoLevel,
		logrus.DebugLevel,
	}
}
