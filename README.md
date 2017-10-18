# Register

`Register` is a project that attempts to distill the [Federal
Register](https://www.federalregister.gov/) data into a more digestible format
with an emphasis on reproducibility for those also interested in the data.

See Releases for the latest csv data. Here are the headers

- date: The date the document appeared in the registry
- type: Presidential / rule / proposed-rule / notice
- agency: What agency issued this document (eg. Department of transportation)
- subject: What is the subject / title of this document
- names: List of names associated with the document (semi-colon delimited)
- rin: List Regulation Identifier Numbers associated with the document (semi-colon delimited)

## Perquisites

If you're interested in reproducing or modifying the resulting data, here is what you need to know:

- You'll want a linux machine to execute the bash scripts to make your life easier
- Java, python3, and [xsv](https://github.com/BurntSushi/xsv) installed
- Patience, as the conversion process takes about 30 minutes

## Quickstart

- `setup.sh`:
  - Download the java library for XQuery files into a `saxon` directory
  - Download the Federal Register data and unzips it into a `data` directory
- `run_conversion.sh`
  - For each Federal Register file:
    - Run the XQuery transformation (`transform.xql`), which outputs JSON
    - Pipe the JSON into the python script (`to_csv.py`), which outputs a CSV file
  - Combine all the CSV files into a single timestamped output using `xsv`
