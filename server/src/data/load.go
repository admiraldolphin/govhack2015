package data

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

const (
	peopleFile     = "people.json"
	portfoliosFile = "portfolios.json"
)

type portfoliosIn struct {
	Portfolios []struct {
		ID       int    `json:id`
		Name     string `json:name`
		Policies []int  `json:policies`
	} `json:portfolios`
}

type personIn struct {
	ID           int `json:id`
	LatestMember struct {
		ID   int `json:id`
		Name struct {
			First string `json:first`
			Last  string `json:last`
		} `json:name`
		Electorate string `json:electorate`
		House      string `json:house`
		Party      string `json:party`
	} `json:latest_member`
}

func Load(basedir string) (*Database, error) {
	db := newDatabase()

	pff, err := os.Open(filepath.Join(basedir, portfoliosFile))
	if err != nil {
		return nil, err
	}
	defer pff.Close()
	dec := json.NewDecoder(pff)
	var pfIn portfoliosIn
	if err := dec.Decode(&pfIn); err != nil {
		return nil, err
	}

	for _, pf := range pfIn.Portfolios {
		db.Portfolios[pf.ID] = Portfolio{
			ID:        pf.ID,
			Name:      pf.Name,
			Questions: pf.Policies,
		}
	}

	pplf, err := os.Open(filepath.Join(basedir, peopleFile))
	if err != nil {
		return nil, err
	}
	var pplIn []personIn
	dec = json.NewDecoder(pplf)
	if err := dec.Decode(&pplIn); err != nil {
		return nil, err
	}
	for _, p := range pplIn {
		db.Heroes[p.ID] = Hero{
			ID:         p.ID,
			Name:       fmt.Sprintf("%s %s", p.LatestMember.Name.First, p.LatestMember.Name.Last),
			Electorate: p.LatestMember.Electorate,
		}
	}

	// TODO: questions?

	return db, nil
}
