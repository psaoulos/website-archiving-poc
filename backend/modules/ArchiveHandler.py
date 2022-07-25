""" Module containting the core difflib implemented functionality. """
import difflib
from modules import Logger, FileSystem, Database

logger = Logger.get_logger()


def calculate_difference_ratio(older_file, newer_file):
    """
    Calculates difference ratio between two archived files.
    1.0 if the sequences are identical, and 0.0 if they have nothing in common.
    """
    try:
        with open(file=older_file, mode="r", encoding="UTF-8").readlines() as file_1:
            with open(file=newer_file, mode="r", encoding="UTF-8").readlines() as file_2:
                seq_mat = difflib.SequenceMatcher()
                seq_mat.set_seqs(file_1, file_2)
                return seq_mat.ratio()
    except Exception as ex:
        logger.error(ex)
        return None


def generate_differences_html(older_file, newer_file):
    """
    Generated printable HTML file containg changes between the two files.
    """
    try:
        with open(file=older_file, mode="r", encoding="UTF-8").readlines() as file_1:
            with open(file=newer_file, mode="r", encoding="UTF-8").readlines() as file_2:
                difference = difflib.HtmlDiff(wrapcolumn=80)
                with open(file="compare.html", mode="w", encoding="UTF-8") as results_file:
                    html = difference.make_file(
                        fromlines=file_1, tolines=file_2, context=True, numlines=3,
                        fromdesc="Original", todesc="Modified"
                    )
                    results_file.write(html)
                    return "compare.html"
    except Exception as ex:
        logger.error(ex)
        return None
