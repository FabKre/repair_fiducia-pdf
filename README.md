# Repair Fiducia-PDF

Shell-Script to repair fiducia-pdf-file (font embedded incorrectly) using qpdf and basic unix tools.

Fiducia is a financial service provider for german Volksbank. They do not embed fonts in generated documents anymore. Futhermore those fonts do not exists, thus those pdfs are rendered ugly in evince (and other viewers using poppler). Font substitution in evince is done correctly and they state "works on my machine".

This scripts maps all Fonts to DejaVuSans (Bold) and DejaVuSansMono (Bold) by extracting font-Flags. Those fonts are not embedded, so will have to download and install them. You may change this mappings (see *SETUP: font substitutions*). 

Please note, that there is an error inside the pdf XREF tables due to the font manipulations, which is automatically fixed by qpdf.

## Getting Started

- download *repair_fiducia-pdf.sh*
- make *repair_fiducia-pdf.sh* executable
- use *./repair_fiducia-pdf.sh <filename>* to repair pdf-file. There will be a backup (*.bak*) of your original file, which you should keep.
- use *./repair_fiducia-pdf.sh -h* to show help
- use *./repair_fiducia-pdf.sh -v* to increase verbosity and show substitutions of fonts

### Prerequisites

- bash cp cut grep rm sed sort strings tr uni
- qpdf

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details