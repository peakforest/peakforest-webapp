package fr.metabohub.mvc.extensions.ajax;

import org.springframework.web.context.request.WebRequest;

public class AjaxUtils {

	public static boolean isAjaxRequest(final WebRequest webRequest) {
		final String requestedWith = webRequest.getHeader("X-Requested-With");
		return requestedWith != null ? "XMLHttpRequest".equals(requestedWith) : false;
	}

	public static boolean isAjaxUploadRequest(final WebRequest webRequest) {
		return webRequest.getParameter("ajaxUpload") != null;
	}

	private AjaxUtils() {
	}

}
