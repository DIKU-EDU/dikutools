# DEPRECATED

See [Staffeli](https://github.com/DIKU-EDU/Staffeli).

## Token

Generér en token på https://absalon.instructure.com/profile/settings og
læg den i en fil ved navn `token`.


## `canvas.py`

Både et bibliotek og et kommandolinjeprogram.


## `absalonfs`

Montér Absalon som et filsystem.  Meget work-in-progress.

```
$ mkdir absalon
$ ./absalonfs absalon
```

## What We (Thus Far) Can't Get To Work

1. Bulk download of submissions is not as easy as fetching the
`submissions_download_url` from [an assignment JSON
object](https://canvas.instructure.com/doc/api/assignments.html#Assignment).
There seems to be some AJAX interaction going on as well.

2. [Upload via
POST](https://canvas.instructure.com/doc/api/file.file_uploads.html#method.file_uploads.post)
fails because in Step 2, Canvas does not provide an `Expires` field among their
`upload_params`, while AWS demands it.
