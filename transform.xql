xquery version "3.1";
declare namespace functx = "http://www.functx.com";

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
    return fn:concat($pieces[4], "-", $month, "-", $pieces[3])
};

declare function local:names($content as node()*) {
    for $raw in $content

		(: A name element can have an emphasis, so all children text is needed
		   to be joined. I'm looking at you <E T="04">Marlene H. Dortch,</E> :)
        let $trim := functx:trim(fn:string-join($raw//text(), ''))

        (: And all names end with a comma, which we dutifully strip :)
        let $name := functx:substring-before-last-match($trim, '[\.,]')
        return $name
};


declare function local:presidential($content as node()*) {
	for $document in $content
        (: Take the first heading to be the title. Also since the heading can
           contain emphasis, we take all nested children text and combine them.
           I'm looking at you <E T="03">Brown</E> v. <E T="03">Board of Education</E> :)
        let $title := fn:string-join($document//HD[@SOURCE='HED'][1]//text(), '')
        return map { 'title': functx:trim($title) }
};

declare function local:rule-extract($content as node()*) {
    for $rule in $content
        (: The trademarked agency: POSTAL SERVICE<E T="51">TM
           must have the trademark included so we take all text and join it :)
        let $ag := fn:string-join($rule/PREAMB/AGENCY[1]//text(), '')
        let $agency := functx:capitalize-first(fn:lower-case($ag))


        (: Join all, as "Revision to the Near-road NO<E T="52">2</E> Minimum
           Monitoring Requirements" will be broken down into two subjects
           (without the "2" in N02) :)
        let $subject := fn:string-join($rule/PREAMB/SUBJECT//text(), '')

        let $rin := $rule/PREAMB/RIN/text()
		return map {
			 'agency': $agency,
             'subject': functx:trim($subject),
             'names': array { local:names($rule//NAME) },
             'rin': $rin
        }
};

map {
    'date': local:parse-date(replace((//DATE)[1]/text(),',','')),
    'presidentials': array { local:presidential(//PRESDOCU) },
    'rules': array { local:rule-extract(//RULES/RULE) },
    'proposed-rules': array { local:rule-extract(//PROFULES/PRORULE) },
    'notices': array { local:rule-extract(//NOTICES/NOTICE) }
}
