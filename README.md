Vision cluster deployment
=========================

This repo includes scripts needed to wipe, reimage, and update the
torralba/billf/oliva vision group visiongpu cluster machines remotely
without physical access.  The scripts are a work-in-progress.

## Installing machines

### Prerequisites

   1. You need sudo access to vision gpu machines.
   2. You run the following from one of the machines listed in `hosts`.

To install vision software on a single machine, or reinstall it
after it has been wiped (or to just update software on the machine
without wiping), run this:

```
./installvisiongpu [gpunum]
```

For example `./installvisiongpu 03` will set up `visiongpu03`.  This
script will run the vision-specific ansible playbook `vision.yml`
to install local versions of vision and deep network libraries.  It
will also restore any saved kerberos configuration from a wipe.  Software
that is installed locally includes:

 * Nvidia CUDA 8.0 from Nvidia's ppa (into `/usr/local/cuda`)
 * Nvidia CUDNN 5, 6, and 7 from Nvidia's debs
   (into `/usr/lib/x86_64-linux-gnu/libcudnn*`)
 * Intel MKL (from intel's debs, into `/opt/intel/mkl`)
 * OpenCV 3.1.0 (built from source, into `/usr/local/lib/libopencv*`)
 * Google protobuf 3 (built from source)
 * System python 2 and python 3 have numpy and scipy installed.
 * A shared root Anaconda install is also present (`/opt/anaconda`)
 * The root anaconda is preloaded with compatible versions of:
    - pytorch (0.2.0)
    - tensorflow (1.2.1)
    - theano (0.9.0)
    - keras (2.0.5)
    - opencv (3.1.0)
 * Also caffe 1.0 (built from source, with python support linked
   to the system python 2.7) (`/opt/caffe`)
 * Monitoring tools `htop` and `glances` (with gpu support) are also installed.
 * A recent version of ansible is installed.
 * Machine-specific profile.local sets up the PATH to include local `conda`,
   `caffe`, etc.

## Wiping machines

Wiping machines has been intermittently flaky and once in a while
requires assistance from TIG.  However, the goal of the script below
is to make it reliable and something you can do without TIG help.

To completely erase local files on a machine and wipe the machine back
to the basic ubuntu system state as installed by TIG, you need serial port
access, which is only available from the machine `holyoke-console`.

### Prerequisites

  1. Obtain the vision ipmi password and place it in `~/.ipmitool/visionpw` with private permissions (ask davidbau or boleizhou for this password.)
  2. ssh into `holyoke-console.csail.mit.edu`, and run the following from there.

```
./wipevisiongpu [gpunum]
```

For example, `./wipevisiongpu 03`.

That script drops into interactive mode for the serial connection,
so at the PXE boot menu, you need to select the 2nd menu option for remote
serial installation, manually.  If any other questions are presented,
just select the defaults.

Wiping will check that nobody is using the machine before wiping it, and
it will save some kerberos information before erasing the machine.
Sometimes the wipe will fail and TIG help may still be required.

## Updating the cluster

The `vision.yml` playbook has all the details for how the vision
software image is installed.  To update all the machines in the cluster
to this basline, list all the machines in `hosts` and then run

```
ansible-playbook vision.yml
```

This playbook requires ansible 2.3 or better, which is available
on all the machines listed in `hosts` (i.e., the machines can update
themselves or each other).  Also note that some of the non-open-source
files needed (CUDNN) cannot be downloaded directly from the
vendor and are provided over NFS, so the playbook needs to be run on a
vision machine.

## TODO

Needed: a similar ansible script (probably a subset) for non-gpu vision
cluster machines.
