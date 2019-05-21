# Register

`Register` is a project that attempts to distill the [Federal
Register](https://www.federalregister.gov/) data into a more digestible format
with an emphasis on reproducibility for those also interested in the data. This
project takes the 7GB of XML data from 2005 to 2018 and condenses it into a
70MB CSV. For more details / background, see the introductory blog post: [Back
to the Register: Distilling the Federal Register for
All](https://nbsoftsolutions.com/blog/back-to-the-register-distilling-the-federal-register-for-all)
(the `sample.R` script is used to generate graphs for that post).

See [Releases for the latest csv
data](https://github.com/nickbabcock/register/releases/latest). Here are the headers

- date: The date the document appeared in the registry
- type: Presidential / rule / proposed-rule / notice
- agency: What agency issued this document (eg. Department of transportation)
- subject: What is the subject / title of this document
- names: List of names associated with the document (semi-colon delimited)
- rin: List Regulation Identifier Numbers associated with the document (semi-colon delimited)

Here's a sample of the data (with subject column removed as Federal Register titles are quite long):

```
date        type    agency                             names               rin            docket
2013-03-20  notice  Department of transportation       G. Kelly Leone                     2013-06361
2015-04-02  notice  Department of veterans affairs     Rebecca Schiller                   2015-07509
2012-11-14  notice  Department of commerce             Gwellnar Banks                     2012-27621
2013-07-22  notice  Federal communications commission  Marlene H. Dortch                  2013-17626
2005-10-19  notice  Environmental protection agency    Vicki A. Simons                    05-20709
2016-02-09  notice  Office of personnel management     Beth F. Cobert                     2016-02615
2013-09-19  rule    Department of the interior         Stephen Guertin     RIN 1018-AY52  2013-22702
2009-05-05  notice  Department of labor                Elliott S. Kushner                 E9-10237
2010-08-03  notice  Small business administration      Karen G. Mills                     2010-19068
2007-09-05  notice  Environmental protection agency    James B. Gulliford                 E7-17542
```

## Contributing

Only a subset of fields available in the Federal Register are extracted into
the CSV. If there is a field missing that you want to see, please open an issue
or create a pull request.

## Perquisites

If you're interested in reproducing or modifying the resulting data, here is what you need to know:

- You'll want a linux machine to execute the bash scripts to make your life easier
- Java and python3

After the above are installed, run the below scripts, which will do the following:

- `setup.sh`:
  - Download the java library for XQuery files into a `saxon` directory
  - Download the Federal Register data into the `data` directory
- `run_conversion.sh`
  - Run the XQuery transformation (`transform.xql`), which outputs JSON lines
  - Pipe the JSON lines into the python script (`to_csv.py`), which outputs a CSV file
