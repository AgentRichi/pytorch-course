FROM jupyter/minimal-notebook

USER root

COPY --chown=${NB_UID}:${NB_GID} pytorch_gpu_course_env.yml /tmp/

RUN fix-permissions $CONDA_DIR

USER $NB_UID

RUN conda env create --quiet -f /tmp/pytorch_gpu_course_env.yml \
#    && conda init bash \
    && source ${CONDA_DIR}/etc/profile.d/conda.sh \
    && conda activate pytorchenv_gpu \
    && conda install --yes -c anaconda ipykernel \
    && python -m ipykernel install --user --name=pytorchenv_gpu \
    && jupyter labextension install --no-build \
      '@krassowski/jupyterlab-lsp@3.5.0' \
    && jupyter lab build --dev-build=False --minimize=True \
    && conda clean --all -f -y \
    && rm -rf \
      $CONDA_DIR/share/jupyter/lab/staging \
      /home/$NB_USER/.cache/yarn \
    && fix-permissions "${CONDA_DIR}" \
    && fix-permissions /home/$NB_USER

# add local repo
RUN mkdir /home/${NB_USER}/pytorch-course
COPY --chown=$NB_UID . /home/${NB_USER}/pytorch-course

# add git global config
RUN git config --global user.email "richard.rossmann@transport.vic.gov.au" \
    && git config --global user.name "Richard Rossmann"
