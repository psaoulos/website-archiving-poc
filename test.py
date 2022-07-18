import difflib

a = open("old.html", "r", encoding='UTF-8').readlines()
b = open("new.html", "r", encoding='UTF-8').readlines()

difference = difflib.HtmlDiff(wrapcolumn=80)

with open("compare.html", "w", encoding='UTF-8') as fp:
    html = difference.make_file(
        fromlines=a, tolines=b,context=True, numlines=3,
        fromdesc="Original", todesc="Modified"
    )
    fp.write(html)

seq_mat = difflib.SequenceMatcher()
seq_mat.set_seqs(a, b)
print(seq_mat.ratio())
