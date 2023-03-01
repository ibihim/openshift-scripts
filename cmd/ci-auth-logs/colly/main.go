/*
MAIN OVERVIEW:
https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/
OVERVIEW:
https://prow.ci.openshift.org/view/gs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/pull-ci-openshift-oauth-server-master-e2e-aws-serial/1491150907654541312
ARTIFACT:
https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/pull-ci-openshift-oauth-server-master-e2e-aws-serial/1491150907654541312/
LIST:
https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/pull-ci-openshift-oauth-server-master-e2e-aws-serial/1491150907654541312/artifacts/e2e-aws-serial/gather-extra/artifacts/pods/
ELEMENT:
https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com
	/gcs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/pull-ci-openshift-oauth-server-master-e2e-aws-serial/1491150907654541312/artifacts/e2e-aws-serial/gather-extra/artifacts/pods
		/openshift-authentication_oauth-openshift-785759cf7c-6wc5f_oauth-openshift.log
*/

package main

import (
	"io"
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/gocolly/colly"
)

func main() {
	err := run("https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/origin-ci-test/pr-logs/pull/openshift_oauth-server/92/")
	if err != nil {
		log.Println(err)
	}
}

func isWithinPath(givenURL, foundURL string) bool {
	return strings.HasPrefix(givenURL, foundURL)
}

func isInterestingLog(u string) bool {
	if !strings.HasSuffix(u, ".log") {
		return false
	}

	listOfInterest := [...]string{
		"openshift-authentication_oauth-openshift",
		"openshift-authentication-operator_authentication-operator",
		"openshift-oauth-apiserver_apiserver",
	}

	for _, s := range listOfInterest {
		if strings.Contains(u, s) {
			return true
		}
	}

	return false
}

func onLink(c *colly.Collector, target string) colly.HTMLCallback {
	return func(e *colly.HTMLElement) {
		link := e.Attr("href")

		if strings.HasSuffix(link, ".log") && !isInterestingLog(link) {
			return
		}

		if !isWithinPath(target, link) {
			return
		}

		if err := c.Visit(e.Request.AbsoluteURL(link)); err != nil {
			log.Println(err)
		}
	}
}

func onRequest(r *colly.Request) {
	u := r.URL.String()
	if !isInterestingLog(u) {
		log.Println("Visiting", u)
	}

	fileNameIdx := strings.LastIndex(r.URL.Path, "/") + 1
	fileName := r.URL.Path[fileNameIdx:]
	file, err := os.Create(fileName)
	if err != nil {
		log.Println(err)
		return
	}
	defer func() {
		if err := file.Close(); err != nil {
			log.Println(err)
		}
	}()

	log.Printf("Writing to %s\n", fileName)
	_, err = io.Copy(file, r.Body)
	if err != nil {
		log.Println(err)
	}
}

func makeFilename(u *url.URL) string {
	chunks := strings.Split(u.Path, "/")
	filename := chunks[len(chunks)-1]

	timestamp 

	return ""
}

func run(target string) error {
	c := colly.NewCollector(
		colly.AllowedDomains(
			"gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com",
			"prow.ci.openshift.org",
		),
	)

	c.OnHTML("a[href]", onLink(c, target))
	c.OnRequest(onRequest)

	if err := c.Visit(target); err != nil {
		return err
	}

	return nil
}
