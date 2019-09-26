FROM wata727/tflint:0.11.2

LABEL "name"="terraform-lint"

LABEL "com.github.actions.name"="Terraform lint"
LABEL "com.github.actions.description"="Lints terraform files in your repository"
LABEL "com.github.actions.icon"="box"
LABEL "com.github.actions.color"="orange"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
