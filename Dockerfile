# Generated by Neurodocker v0.2.0-dev.
#
# Thank you for using Neurodocker. If you discover any issues 
# or ways to improve this software, please submit an issue or 
# pull request on our GitHub repository:
#     https://github.com/kaczmarj/neurodocker
#
# Timestamp: 2017-08-14 20:18:30

FROM neurodebian:stretch-non-free

ARG DEBIAN_FRONTEND=noninteractive

#----------------------------------------------------------
# Install common dependencies and create default entrypoint
#----------------------------------------------------------
ENV LANG="C.UTF-8" \
    LC_ALL="C" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN apt-get update -qq && apt-get install -yq --no-install-recommends  \
    	bzip2 ca-certificates curl unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir /neurodocker \
    && echo '#!/usr/bin/env bash' >> $ND_ENTRYPOINT \
    && echo 'set +x' >> $ND_ENTRYPOINT \
    && echo 'if [ -z "$*" ]; then /usr/bin/env bash; else $*; fi' >> $ND_ENTRYPOINT \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker
ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq && apt-get install -yq --no-install-recommends tree git-annex-standalone vim emacs-nox nano less ncdu tig git-annex-remote-rclone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# User-defined instruction
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update -qq && apt-get install -yq --no-install-recommends nodejs build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# User-defined instruction
ENV LC_ALL=C.UTF-8

# User-defined instruction
RUN apt-get update && apt-get install -yq xvfb mesa-utils

# Create new user: neuro
RUN useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

#------------------
# Install Miniconda
#------------------
ENV CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:$PATH
RUN echo "Downloading Miniconda installer ..." \
    && miniconda_installer=/tmp/miniconda.sh \
    && curl -sSL -o $miniconda_installer https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && /bin/bash $miniconda_installer -f -b -p $CONDA_DIR \
    && rm -f $miniconda_installer \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && conda update -y --all \
    && conda clean -tipsy \
    && find /opt/conda -name ".wh*" -exec rm {} +

#-------------------------
# Create conda environment
#-------------------------
RUN conda create -y -q --name neuro python=3.6 \
    	jupyter jupyterlab pandas matplotlib scikit-learn seaborn altair traitsui apptools configobj reprozip reprounzip vtk \
    && conda clean -tipsy \
    && /bin/bash -c "source activate neuro \
    	&& pip install -q --no-cache-dir \
    	nilearn datalad mayavi" \
    && find /opt/conda -name ".wh*" -exec rm {} +
ENV PATH=/opt/conda/envs/neuro/bin:$PATH

# User-defined instruction
RUN bash -c "source activate neuro && pip install --pre --upgrade ipywidgets pythreejs " 

# User-defined instruction
RUN bash -c "source activate neuro && pip install  --upgrade https://github.com/maartenbreddels/ipyvolume/archive/master.zip && jupyter nbextension install --py --sys-prefix ipyvolume && jupyter nbextension enable --py --sys-prefix ipyvolume " 

# User-defined instruction
RUN bash -c "source activate neuro && conda install jupyter_contrib_nbextensions " 

# User-defined instruction
RUN bash -c "source activate neuro && pip install --upgrade https://github.com/nipy/nibabel/archive/master.zip " 

# User-defined instruction
COPY cifti-data /cifti-data

# User-defined instruction
USER root

# User-defined instruction
RUN chmod -R a+r /cifti-data 

# User-defined instruction
USER neuro

WORKDIR /home/neuro
