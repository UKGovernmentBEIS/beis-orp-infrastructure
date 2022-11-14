resource "aws_iam_role" "ecs_host" {
  name               = "ecs_webserver_host"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "ecs_svc" {
  name               = "ecs_webserver_svc"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "ecs_beis" {
  name               = "ecs_beis"
  assume_role_policy = data.aws_iam_policy_document.beis_ecs_assume_role.json
}

resource "aws_iam_role_policy" "ecs_instance_policy" {
  name   = "ecs_webserver_instance_policy"
  policy = data.aws_iam_policy_document.ecs_instance.json
  role   = aws_iam_role.ecs_host.id
}

resource "aws_iam_role_policy" "ecs_svc_policy" {
  name   = "ecs_webserver_svc_policy"
  policy = data.aws_iam_policy_document.ecs_svc.json
  role   = aws_iam_role.ecs_svc.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_webserver_instance_profile"
  role = aws_iam_role.ecs_host.name
}

resource "aws_iam_role_policy_attachment" "multiple_policy" {
  for_each   = local.ecs_policies
  policy_arn = each.value
  role       = aws_iam_role.ecs_host.name
}
