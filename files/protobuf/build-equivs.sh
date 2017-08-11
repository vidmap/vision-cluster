#!/bin/sh

ls equivs/* | xargs -I{} -n 1 equivs-build {}
