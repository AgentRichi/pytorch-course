FROM jupyter/minimal-notebook

USER root

# copy config files
COPY --chown=${NB_UID}:${NB_GID} pytorch_course_env.yml /tmp/
COPY --chown=${NB_UID}:${NB_GID} pytorch_gpu_course_env.yml /tmp/
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

RUN fix-permissions $CONDA_DIR

USER $NB_UID

# install python packages and jupyterlab extensions
RUN conda install -c conda-forge --quiet --yes --file /tmp/requirements.txt \
    && jupyter labextension install --no-build '@krassowski/jupyterlab-lsp@3.5.0' \
    && jupyter lab build --dev-build=False --minimize=True \
    && conda clean --all -f -y \
    && rm -rf \
      $CONDA_DIR/share/jupyter/lab/staging \
      /home/$NB_USER/.cache/yarn \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions /home/$NB_USER

RUN mkdir /home/$NB_USER/conda_envs

# create CPU enviroment
RUN mkdir /home/$NB_USER/conda_envs/pytorchenv \
    && conda env create --quiet -f /tmp/pytorch_course_env.yml -p /home/$NB_USER/conda_envs/pytorchenv  \
    && source ${CONDA_DIR}/etc/profile.d/conda.sh \
    && conda activate /home/$NB_USER/conda_envs/pytorchenv \
    && conda install -c conda-forge --quiet --yes --file /tmp/requirements.txt \
    && python -m ipykernel install --user --name=pytorchenv \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions /home/$NB_USER

# create GPU enviroment
RUN mkdir /home/$NB_USER/conda_envs/pytorchenv_gpu \
    && conda env create --quiet -f /tmp/pytorch_gpu_course_env.yml -p /home/$NB_USER/conda_envs/pytorchenv_gpu \
    && source ${CONDA_DIR}/etc/profile.d/conda.sh \
    && conda activate /home/$NB_USER/conda_envs/pytorchenv_gpu \
    && conda install -c conda-forge --quiet --yes --file /tmp/requirements.txt \
    && python -m ipykernel install --user --name=pytorchenv_gpu \
    && conda clean --all -f -y \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions /home/$NB_USER

# add local repo
RUN mkdir /home/${NB_USER}/pytorch-course
COPY --chown=$NB_UID . /home/${NB_USER}/pytorch-course

# symbiotic links, required for jumping to source code
RUN mkdir /home/${NB_USER}/.lsp_symlink \
    && cd /home/${NB_USER}/.lsp_symlink \
    && mkdir -p opt/conda/lib \
    && mkdir -p home/$NB_USER/conda_envs/pytorchenv/lib \
    && mkdir -p home/$NB_USER/conda_envs/pytorchenv_gpu/lib \
    && ln -s /opt/conda/lib/python3.8 opt/conda/lib/python3.8 \
    && ln -s /home/$NB_USER/conda_envs/pytorchenv/lib/python3.7 home/$NB_USER/conda_envs/pytorchenv/lib/python3.7 \
    && ln -s /home/$NB_USER/conda_envs/pytorchenv_gpu/lib/python3.7 home/$NB_USER/conda_envs/pytorchenv_gpu/lib/python3.7

# add git global config
RUN git config --global user.email "richard.rossmann@transport.vic.gov.au" \
    && git config --global user.name "Richard Rossmann"
