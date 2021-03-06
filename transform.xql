xquery version "3.1";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace functx = "http://www.functx.com";
declare option output:item-separator "&#xa;";

declare function functx:trim
  ( $arg as xs:string? )  as xs:string {

   replace(replace($arg,'\s+$',''),'^\s+','')
 } ;

declare function functx:substring-before-last-match
  ( $arg as xs:string? ,
    $regex as xs:string )  as xs:string? {

   replace($arg,concat('^(.*)',$regex,'.*'),'$1')
 } ;

declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;

(: Dates in the register look like "Tuesday, September 5, 2006", which is not
   the friendliest form for a computer, so we convert it to "2006-09-05", which is
   a ISO 8601 date formatted string :)
declare function local:parse-date($date as xs:string) {
    let $pieces := fn:tokenize($date, " ")
    let $map := map {
        "January": "01",
        "February": "02",
        "March": "03",
        "April": "04",
        "May": "05",
        "June": "06",
        "July": "07",
        "August": "08",
        "September": "09",
        "October": "10",
        "November": "11",
        "December": "12"
    }
    let $month := $map($pieces[2])

	(: Add leading zeros to date if needed, so "5" becomes "05" :)
    let $day := format-number(number($pieces[3]), '00')
    return fn:concat($pieces[4], "-", $month, "-", $day)
};

declare function local:names($content as node()*) {
    for $raw in $content

        (: A name element can have an emphasis, so all children text is needed
           to be joined. I'm looking at you <E T="04">Marlene H. Dortch,</E> :)
        let $trim := functx:trim(fn:string-join($raw//text(), ''))

        (: And all names end with a comma or semi-colon, which we dutifully
           strip. The one semicolon seen is for a George Aiken for the 2006-09-14
           publication :)
        let $name := functx:substring-before-last-match($trim, '[\.;,]')
        return $name
};

declare function local:docket($content as node()?) {
    (: PRTPAGE can appear right in the middle of a docket, so we must first
       ignore it by grabbing all children text :)
    let $norm := fn:string-join($content//text(),'')
    return fn:tokenize($norm, ' ')[3]
};

declare function local:presidential($content as node()*) {
    for $document in $content
        (: Take the first heading to be the title. Also since the heading can
           contain emphasis, we take all nested children text and combine them.
           I'm looking at you <E T="03">Brown</E> v. <E T="03">Board of Education</E> :)
        let $title := fn:string-join($document//HD[@SOURCE='HED'][1]//text(), '')
        let $docket := local:docket($document//FRDOC)

        return map { 'title': functx:trim($title), 'docket': $docket }
};

declare function local:fix-subject($content as node()*) {
    for $subject in $content
        return functx:trim($subject)
};

declare function local:rule-extract($content as node()*) {
    for $rule in $content
        (: The trademarked agency: POSTAL SERVICE<E T="51">TM
           must have the trademark included so we take all text and join it :)
        let $ag := functx:trim(fn:string-join($rule/PREAMB/AGENCY[1]//text(), ''))
        let $agency := functx:capitalize-first(fn:lower-case($ag))

        let $sag := functx:trim(fn:string-join($rule/PREAMB/SUBAGY[1]//text(), ''))
        let $sub_agency := functx:capitalize-first(fn:lower-case($sag))

        let $docket := local:docket($rule/FRDOC)

        (: Join all, as "Revision to the Near-road NO<E T="52">2</E> Minimum
           Monitoring Requirements" will be broken down into two subjects
           (without the "2" in N02). Also remove all superscripts (SU) (which
           cause a line break). `//` is an alias for
           `descendant-or-self::node()`, so we use that with the xpath 2.0
           except operator  :)
        let $subjects := $rule/PREAMB/SUBJECT/(descendant-or-self::node() except SU)/text()
        let $subject := fn:string-join(local:fix-subject($subjects), '')

        (: There can be multiple rins (Regulation Identifier Numbers)
           associated with a rule, see: RIN 1653-AA41 and RIN 1125-AA50 :)
        let $rin := $rule/PREAMB/RIN/text()
        return map {
             'agency': $agency,
             'sub_agency': $sub_agency,
             'subject': functx:trim($subject),
             'names': array { local:names($rule//NAME) },
             'rin': array { $rin },
             'docket': $docket
        }
};


for $year in (2005 to year-from-date(current-date()))
for $v in collection('data/FR-' || $year || '.zip')
return serialize(map {
    'date': local:parse-date(replace($v/FEDREG/DATE[1]/text(),',','')),
    'presidentials': array { local:presidential($v//PRESDOCU) },
    'rules': array { local:rule-extract($v//RULES/RULE) },
    'proposed-rules': array { local:rule-extract($v//PRORULES/PRORULE) },
    'notices': array { local:rule-extract($v//NOTICES/NOTICE) }
}, map { 'method': 'json' })
