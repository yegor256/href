# (The MIT License)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

.SHELLFLAGS = -e -x -c
.ONESHELL:

all: href-ul.pdf copyright zip

copyright:
	grep -q -r "2021-$$(date +%Y)" --include '*.tex' --include '*.sty' --include 'Makefile' .

href-ul.pdf: href-ul.tex href-ul.sty
	latexmk -pdf $<
	texsc $<
	texqc --ignore 'You have requested document class' $<

zip: href-ul.pdf href-ul.sty
	rm -rf package
	mkdir package
	cd package
	mkdir href-ul
	cd href-ul
	cp ../../README.md .
	version=$$(curl --silent -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/yegor256/href-ul/releases/latest | jq -r '.tag_name')
	echo "Version is: $${version}"
	date=$$(date +%Y/%m/%d)
	echo "Date is: $${date}"
	cp ../../href-ul.sty .
	gsed -i "s|0\.0\.0|$${version}|" href-ul.sty
	gsed -i "s|00\.00\.0000|$${date}|" href-ul.sty
	cp ../../href-ul.tex .
	gsed -i "s|0\.0\.0|$${version}|" href-ul.tex
	gsed -i "s|00\.00\.0000|$${date}|" href-ul.tex
	cp ../../.latexmkrc .
	latexmk -pdf href-ul.tex
	rm .latexmkrc
	rm -rf _minted-* *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.log *.run.xml *.out *.exc
	cat href-ul.sty | grep RequirePackage | gsed -e "s/.*{\(.\+\)}.*/hard \1/" > DEPENDS.txt
	cd ..
	zip -r href-ul-$${version}.zip *
	cp href-ul-$${version}.zip ..
	cd ..

clean:
	git clean -dfX
