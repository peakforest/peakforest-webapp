package fr.metabohub.peakforest.utils;

import java.util.Locale;

import javax.mail.MessagingException;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMessage.RecipientType;

import org.springframework.context.MessageSource;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;

/**
 * Class use to SEND emails
 * 
 * @author Nils Paulhe
 * 
 */
public class EmailManager {

	private MessageSource messageSource = null;
	private String from = null;
	private String messageBCC1 = null;
	private String messageBCC2 = null;
	private String replyTo = null;
	private JavaMailSenderImpl sender = null;

	public EmailManager(//
			final String host, //
			final boolean authenticate, //
			final String username, //
			final String password//
	) {
		super();
		final JavaMailSenderImpl sender = new JavaMailSenderImpl();
		sender.setHost(host);
		if (authenticate) {
			sender.setUsername(username);
			sender.setPassword(password);
			sender.setPort(465);
			sender.getJavaMailProperties().put("mail.smtp.starttls.enable", "true");
//			final Properties props = sender.getJavaMailProperties();
//			props.put("mail.smtp.starttls.enable", "true");
//			sender.setJavaMailProperties(props);
		}
		this.sender = sender;
	}

	public MessageSource getMessageSource() {
		return messageSource;
	}

	public void setMessageSource(final MessageSource messageSource) {
		this.messageSource = messageSource;
	}

	public JavaMailSenderImpl getSender() {
		return sender;
	}

	public void setSender(final JavaMailSenderImpl sender) {
		this.sender = sender;
	}

	public String getFrom() {
		return from;
	}

	public void setFrom(final String from) {
		this.from = from;
	}

	public boolean sendAccountCreationEmail(//
			final Locale locale, //
			final String userEmail//
	)//
			throws AddressException, MessagingException {
		final String emailTitle = messageSource.getMessage("email.register.title", null, locale);
		final String emailPart1 = messageSource.getMessage("email.register.part1", null, locale)//
				.replaceAll("%INSTANCE%", PeakForestUtils.getBundleConfElement("peakforest.webapp.url"));
		final String emailPart2 = messageSource.getMessage("email.register.part2", null, locale);
		final String emailPart3 = messageSource.getMessage("email.register.part3", null, locale);
		final InternetAddress replyToArray[] = new InternetAddress[] { new InternetAddress(replyTo) };
		final MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));
		message.addRecipient(RecipientType.BCC, new InternetAddress(messageBCC1));
		message.addRecipient(RecipientType.BCC, new InternetAddress(messageBCC2));
		message.setReplyTo(replyToArray);
		final MimeMessageHelper helper = new MimeMessageHelper(message, Boolean.TRUE, "UTF-8");
		helper.setFrom(this.from);
		helper.setTo(userEmail);
		helper.setSubject(emailTitle);
		helper.setText("<html><body>" + emailPart1 + "\n<br />\n<br />" + emailPart2 + " " + userEmail + "\n<br />"
				+ emailPart3 + "</body></html>", Boolean.TRUE);
		sender.send(message);
		return Boolean.TRUE;
	}

	public boolean sendPasswordResetEmail(//
			final Locale locale, //
			final String userEmail, //
			final String newPassword//
	) throws AddressException, MessagingException {
		final String subject = messageSource.getMessage("email.resetpassword.title", null, locale);
		final String emailPart1 = messageSource.getMessage("email.resetpassword.part1", null, locale);
		final String emailPart2 = messageSource.getMessage("email.resetpassword.part2", null, locale);
		final String emailPart3 = messageSource.getMessage("email.resetpassword.part3", null, locale);
		final MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));
		final MimeMessageHelper helper = new MimeMessageHelper(message, Boolean.TRUE, "UTF-8");
		helper.setFrom(from);
		helper.setTo(userEmail);
		helper.setSubject(subject);
		helper.setText("<html><body>" + emailPart1 + " \n<br />" + "\n<br />" + emailPart2 + "<br />" + "\n<br />"
				+ emailPart3 + " \n<br />" + newPassword + "</body></html>", true);
		sender.send(message);
		return Boolean.TRUE;
	}

	public boolean sendEmail(//
			final String userEmail, //
			final String messageSubject, //
			final String messageConent, //
			final boolean isHTML//
	) throws AddressException, MessagingException {
		final MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));
		final MimeMessageHelper helper = new MimeMessageHelper(message, Boolean.TRUE, "UTF-8");
		helper.setFrom(from);
		helper.setTo(userEmail);
		helper.setSubject(messageSubject);
		helper.setText(messageConent, isHTML);
		sender.send(message);
		return Boolean.TRUE;
	}

	public String getMessageBCC1() {
		return messageBCC1;
	}

	public void setMessageBCC1(final String messageBCC) {
		this.messageBCC1 = messageBCC;
	}

	public String getMessageBCC2() {
		return messageBCC2;
	}

	public void setMessageBCC2(final String messageBCC) {
		this.messageBCC2 = messageBCC;
	}

	public String getReplyTo() {
		return this.replyTo;
	}

	public void setReplyTo(final String replyTo) {
		this.replyTo = replyTo;
	}

}
