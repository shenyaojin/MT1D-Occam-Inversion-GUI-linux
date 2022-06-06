import os
import numpy


# dependent: mt1docc.

def mt1dinv(filename, nlayer, maxit, tol, mode, noise):
    # get the site name::
    sitename = filename.split("/")
    end = len(sitename) - 1
    sitename = (sitename[end].split("."))[0]
    ediname = sitename + '.edi'

    # make temporary folder "edi"
    os.system("mkdir edi")
    # add edi file to folder edi.
    os.system("cp %s edi/%s" % (filename, ediname))  # move the edi file to temp.
    # move makefile from lib to workspace
    os.system("cp lib/Makefile Makefile")
    os.system("cp lib/Makefile_1DMTOCC Makefile_1DMTOCC")
    os.system("cp lib/script_generate_depth_slice.sh script_generate_depth_slice.sh")

    # set default parameters
    if nlayer == -1:
        nlayer = 20
    if maxit == -1:
        maxit = 10
    if tol == -1:
        tol = 1.2
    if mode == -1:
        mode = 3
    if noise == -1:
        noise = 6
    # create file: png.list and move it into the temp folder::
    f = open("png.list", 'w')
    f.write("png=\\\n")
    png_name = sitename + ".png \\"
    f.write(png_name)
    f.close()

    # Create the mkpara.sh file and move it into the temp folder::
    f = open("mkpara.sh", 'w')
    f.write("#!/bin/bash\nsite=$1\n#\n# see if there is a mk.para file exist.\n#\nif [ -e mk.para ]; then echo \"mk.par"
            "a existed!\"; exit; fi\n")
    f.write("echo \"site=\"$site > mk.para\n")
    f.write("echo \"inv=\"$site.RECV >> mk.para\n")
    f.write("echo \"nlayer=")
    f.write(str(nlayer))
    f.write("\" >> mk.para\n")
    f.write("echo \"mfile=\"$site.mod >> mk.para\necho \"dfile=\"$site.dat >> mk.para\n")

    f.write("echo \"maxit=")
    f.write(str(maxit))
    f.write("\" >> mk.para\n")

    f.write("echo \"tol=")
    f.write(str(tol))
    f.write("\" >> mk.para\n")

    f.write("echo \"mode=")
    f.write(str(mode))
    f.write("\" >> mk.para\n")

    f.write("echo \"noise=")
    f.write(str(noise))
    f.write("\" >> mk.para\n")

    f.close()
    os.system("cp lib/edi2ztab.sh edi2ztab.sh")
    os.system("cp lib/mt1docc mt1docc")
    os.system("make")

    # delete the temp files:
    os.system("rm edi2ztab.sh")
    os.system("rm Makefile")
    os.system("rm Makefile_1DMTOCC")
    os.system("rm mkpara.sh")
    os.system("rm mt1docc")
    os.system("rm png.list")
    os.system("rm script_generate_depth_slice.sh")
    command = "rm -r "+sitename
    os.system(command)

    # move the result to a folder::
    folder_name = filename.strip(".edi")
    command = "mkdir " + folder_name
    os.system(command)
    # move results to this folder::
    png_name = sitename + ".png"
    recv_name = sitename + ".RECV"
    resp_name = sitename + ".RESP"

    command = "mv " + png_name + " " + folder_name + "/"
    # print(command)
    os.system(command)
    print(".PNG move to %s" % folder_name)
    command = "mv " + recv_name + " " + folder_name + "/"
    os.system(command)
    print(".RECV move to %s" % folder_name)
    command = "mv " + resp_name + " " + folder_name + "/"
    os.system(command)
    print(".RESP move to %s" % folder_name)
    print("Procedure Complete. There's no error.")
