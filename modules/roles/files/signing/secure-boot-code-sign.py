#!/usr/bin/python3

# Copyright (C) 2017 Collabora Ltd
# 2017 Helen Koike <helen.koike@collabora.com>
#
# Ported from bash to python3 by Julien Cristau <jcristau@debian.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

import argparse
import configparser
import os
import subprocess
import sys
import tarfile
import tempfile


config = {}


def sign(extract_dir, signed_dir):
    for dirpath, dirnames, filenames in os.walk(extract_dir):
        assert dirpath.startswith(extract_dir)
        out_dir = signed_dir + dirpath[len(extract_dir):]
        os.makedirs(out_dir)
        for filename in filenames:
            #print(os.path.join(dirpath, filename), file=sys.stderr)
            if filename.endswith('.efi') or filename.startswith('vmlinuz-'):
                sign_efi(os.path.join(dirpath, filename), os.path.join(out_dir, filename + '.sig'))
            elif filename.endswith('.ko'):
                sign_kmod(os.path.join(dirpath, filename), os.path.join(out_dir, filename + '.sig'))
            else:
                print("ignoring %s" % os.path.join(dirpath, filename), file=sys.stderr)


def sign_kmod(module_path, signature_path):
    assert 'linux_sign_file' in config
    assert 'pkcs11_uri' in config
    assert 'cert_path' in config
    assert 'pin' in config

    env = os.environ.copy()
    env['KBUILD_SIGN_PIN'] = config['pin']
    # use check_output instead of check_call as sign-file seems to send random
    # stuff to stderr even when it succeeds
    subprocess.check_output(
	[config['linux_sign_file'], '-d', 'sha256', config['pkcs11_uri'],
	 config['cert_path'], module_path],
	env=env, stderr=subprocess.STDOUT)
    os.rename(module_path + '.p7s', signature_path)


def sign_efi(efi_path, signature_path):
    assert 'sign-efi' in config
    assert 'certdir' in config
    assert 'token' in config
    assert 'certname' in config
    assert 'pin' in config

    env = os.environ.copy()
    env['PESIGN_PIN'] = config['pin']
    with open(signature_path, 'wb') as out:
        subprocess.check_call(
	    [config['sign-efi'], config['certdir'], config['token'],
	     config['certname'], efi_path],
	    env=env, stdout=out)


def extract(tar_file, extract_dir):
    with tarfile.TarFile.open(fileobj=tar_file, mode="r:xz") as f:
        def is_within_directory(directory, target):
            
            abs_directory = os.path.abspath(directory)
            abs_target = os.path.abspath(target)
        
            prefix = os.path.commonprefix([abs_directory, abs_target])
            
            return prefix == abs_directory
        
        def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
        
            for member in tar.getmembers():
                member_path = os.path.join(path, member.name)
                if not is_within_directory(path, member_path):
                    raise Exception("Attempted Path Traversal in Tar File")
        
            tar.extractall(path, members, numeric_owner=numeric_owner) 
            
        
        safe_extract(f, extract_dir)


def repack(signed_dir, fileobj):
    def cleanup_tarinfo(tarinfo):
        tarinfo.path = os.path.relpath('/' + tarinfo.path, signed_dir)
        tarinfo.gid = 0
        tarinfo.gname = 'root'
        tarinfo.uid = 0
        tarinfo.uname = 'root'
        return tarinfo

    with tarfile.TarFile.open(mode='w:xz', fileobj=fileobj) as f:
        f.add(signed_dir, filter=cleanup_tarinfo)


def main():
    parser = argparse.ArgumentParser(
            description='sign files in a tarball')
    parser.add_argument('input_tar', metavar='input', type=argparse.FileType('rb'),
            help='tarball containing files to be signed')
    parser.add_argument('--config', '-c', type=str,
            default='/etc/codesign.ini', help='configuration file')

    args = parser.parse_args()

    cp = configparser.RawConfigParser()
    cp.read(args.config)

    # path to the sign-file command from Linux
    config['linux_sign_file'] = cp.get('commands', 'sign-kmod',
            fallback='/usr/lib/linux-kbuild-4.9/scripts/sign-file')
    # pkcs11 uri from `p11tool --list-token-urls`
    config['pkcs11_uri'] = cp.get('efi', 'pkcs11_uri')
    # path to the PEM or DER-format certificate
    config['cert_path'] = cp.get('efi', 'cert_path')

    # path to our pesign wrapper script
    config['sign-efi'] = cp.get('commands', 'sign-efi', fallback='/usr/local/bin/pesign-wrap')
    # path to the nss store
    config['certdir'] = cp.get('efi', 'certdir', fallback='/srv/codesign/pki')
    # name of the token in the nss store
    config['token'] = cp.get('efi','token', fallback='PIV_II (PIV Card Holder pin)')
    # name of the cert in the nss store
    config['certname'] = cp.get('efi', 'cert', fallback='Certificate for Digital Signature')

    config['pin'] = cp.get('efi', 'pin')

    workdir = tempfile.TemporaryDirectory()
    with workdir:
        extract_dir = os.path.join(workdir.name, 'in')
        signed_dir = os.path.join(workdir.name, 'out')
        extract(args.input_tar, extract_dir)
        sign(extract_dir, signed_dir)
        repack(signed_dir, sys.stdout.buffer)


if __name__ == '__main__':
    sys.exit(main())
