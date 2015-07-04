package data

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
)

const (
	peopleFile     = "people.json"
	portfoliosFile = "portfolios.json"
	detailDir      = "people"
	detailFmt      = "%d.json"
)

type portfoliosIn struct {
	Portfolios []struct {
		ID       int    `json:"id"`
		Name     string `json:"name"`
		Policies []int  `json:"policies"`
	} `json:"portfolios"`
}

type personIn struct {
	ID           int `json:"id"`
	LatestMember struct {
		ID   int `json:"id"`
		Name struct {
			First string `json:"first"`
			Last  string `json:"last"`
		} `json:"name"`
		Electorate string `json:"electorate"`
		House      string `json:"house"`
		Party      string `json:"party"`
	} `json:"latest_member"`
}

type detailIn struct {
	ID           int `json:"id"`
	LatestMember struct {
		ID   int `json:"id"`
		Name struct {
			First string `json:"first"`
			Last  string `json:"last"`
		} `json:"name"`
		Electorate string `json:"electorate"`
		House      string `json:"house"`
		Party      string `json:"party"`
	} `json:"latest_member"`
	Offices []struct {
		Position string `json:"position"`
	} `json:"offices"`
	PolicyComparisons []struct {
		Agreement string `json:"agreement"`
		Policy    struct {
			ID          int    `json:"id"`
			Name        string `json:"name"`
			Description string `json:"description"`
			Provisional bool   `json:"provisional"`
		} `json:"policy"`
		Voted bool `json:"voted"`
	} `json:"policy_comparisons"`
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
	log.Printf("Loaded %d portfolios", len(db.Portfolios))

	pplf, err := os.Open(filepath.Join(basedir, peopleFile))
	if err != nil {
		return nil, err
	}
	var pplIn []personIn
	dec = json.NewDecoder(pplf)
	if err := dec.Decode(&pplIn); err != nil {
		return nil, err
	}
	log.Printf("Loaded %d people", len(pplIn))

	ansCount := 0
	detailPath := filepath.Join(basedir, detailDir)
	for _, p := range pplIn {
		pf, err := os.Open(filepath.Join(detailPath, fmt.Sprintf(detailFmt, p.ID)))
		if err != nil {
			return nil, err
		}
		defer pf.Close()
		var detIn detailIn
		dec := json.NewDecoder(pf)
		if err := dec.Decode(&detIn); err != nil {
			return nil, err
		}
		pf.Close()
		ans := make(map[int]Answer)
		for _, pc := range detIn.PolicyComparisons {
			a, err := strconv.ParseFloat(pc.Agreement, 64)
			if err != nil {
				return nil, err
			}
			switch {
			case !pc.Voted:
				ans[pc.Policy.ID] = Abstain
			case 0 <= a && a <= 20:
				ans[pc.Policy.ID] = DisagreeStrong
			case 20 < a && a <= 40:
				ans[pc.Policy.ID] = Disagree
			case 40 < a && a <= 60:
				ans[pc.Policy.ID] = Neutral
			case 60 < a && a <= 80:
				ans[pc.Policy.ID] = Agree
			case 80 < a && a <= 100:
				ans[pc.Policy.ID] = AgreeStrong
			default:
				return nil, fmt.Errorf("agreement out of range [%f notin 0..100]", a)
			}
		}

		db.Heroes[p.ID] = Hero{
			ID:         detIn.ID,
			Name:       fmt.Sprintf("%s %s", detIn.LatestMember.Name.First, detIn.LatestMember.Name.Last),
			Electorate: detIn.LatestMember.Electorate,
			Answers:    ans,
		}
		ansCount += len(ans)
	}
	log.Printf("Loaded %d answers", ansCount)
	return db, nil
}
