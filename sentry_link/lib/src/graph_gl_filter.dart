import 'package:sentry/sentry.dart';

BeforeBreadcrumbCallback graphQlFilter([BeforeBreadcrumbCallback? filter]) {
  return (
    Breadcrumb? ogBreadcrumb, {
    Hint? hint,
  }) {
    final breadCrumb = filter?.call(ogBreadcrumb, hint: hint);
    if (breadCrumb == null) {
      return null;
    }

    if (!(breadCrumb.type == 'http' && breadCrumb.category == 'http')) {
      return breadCrumb;
    }

    final url = breadCrumb.data?['url'] as String?;
    if (url?.contains('/graphql') ?? false) {
      // filter any request to "https://example.org/graphql"
      return null;
    }
    return breadCrumb;
  };
}
