#!/usr/bin/env bash

set -e

tracer_url=$1
proflier_url=$2

tmp_folder=/tmp/dd-library-php
tmp_folder_tracer=$tmp_folder/tracer
tmp_folder_tracer_archive=$tmp_folder_tracer/datadog-tracer.targ.gz
tmp_folder_profiler=$tmp_folder/profiler
tmp_folder_profiler_archive=$tmp_folder_profiler/datadog-profiling.targ.gz
tmp_folder_final=$tmp_folder/final
tmp_folder_final_tracer=$tmp_folder_final/tracer
tmp_folder_final_profiler=$tmp_folder_final/profiler

# Starting from a clean folder
rm -rf $tmp_folder
mkdir -p $tmp_folder_tracer
mkdir -p $tmp_folder_profiler
mkdir -p $tmp_folder_final

########################
# Tracer
########################
curl -L -o $tmp_folder_tracer_archive $tracer_url
tar -xf $tmp_folder_tracer_archive -C $tmp_folder_tracer

# Bridge folder
mkdir -p $tmp_folder_final/x86_64-gnu/datadog-library/tracer $tmp_folder_final/x86_64-musl/datadog-library/tracer
cp -r $tmp_folder_tracer/opt/datadog-php/dd-trace-sources/bridge $tmp_folder_final/x86_64-gnu/datadog-library/tracer
cp -r $tmp_folder_tracer/opt/datadog-php/dd-trace-sources/bridge $tmp_folder_final/x86_64-musl/datadog-library/tracer

# Extension
php_apis=(20100412 20121113 20131106 20151012 20160303 20170718 20180731 20190902 20200930 20210902)
for version in "${php_apis[@]}"
do
    mkdir -p $tmp_folder_final/x86_64-gnu/datadog-library/tracer/ext/$version $tmp_folder_final/x86_64-musl/datadog-library/tracer/ext/$version
    cp $tmp_folder_tracer/opt/datadog-php/extensions/ddtrace-$version.so $tmp_folder_final/x86_64-gnu/datadog-library/tracer/ext/$version/datadog-trace.so
    cp $tmp_folder_tracer/opt/datadog-php/extensions/ddtrace-$version-zts.so $tmp_folder_final/x86_64-gnu/datadog-library/tracer/ext/$version/datadog-trace-zts.so
    cp $tmp_folder_tracer/opt/datadog-php/extensions/ddtrace-$version-debug.so $tmp_folder_final/x86_64-gnu/datadog-library/tracer/ext/$version/datadog-trace-debug.so
    cp $tmp_folder_tracer/opt/datadog-php/extensions/ddtrace-$version-alpine.so $tmp_folder_final/x86_64-musl/datadog-library/tracer/ext/$version/datadog-trace.so
done

########################
# Profiler
########################
curl -L -o $tmp_folder_profiler_archive $proflier_url
tar -xf $tmp_folder_profiler_archive -C $tmp_folder_profiler

# Extension
php_apis=(20160303 20170718 20180731 20190902 20200930)
for version in "${php_apis[@]}"
do
    mkdir -p $tmp_folder_final/x86_64-gnu/datadog-library/profiler/ext/$version $tmp_folder_final/x86_64-musl/datadog-library/profiler/ext/$version
    cp $tmp_folder_profiler/datadog-profiling-x86_64-linux/gnu/lib/$version/datadog-profiling.so $tmp_folder_final/x86_64-gnu/datadog-library/profiler/ext/$version/datadog-profiling.so
    cp $tmp_folder_profiler/datadog-profiling-x86_64-linux/musl/lib/$version/datadog-profiling.so $tmp_folder_final/x86_64-musl/datadog-library/profiler/ext/$version/datadog-profiling.so
done

########################
# Final archives
########################
tar -czvf dd-library-php-x86_64-gnu.tar.gz -C /tmp/dd-library-php/final/x86_64-gnu .
tar -czvf dd-library-php-x86_64-musl.tar.gz -C /tmp/dd-library-php/final/x86_64-musl .
