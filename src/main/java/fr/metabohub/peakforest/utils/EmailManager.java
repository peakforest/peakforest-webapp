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
	private JavaMailSenderImpl sender = null;

	/**
	 * @param host
	 * @param authenticate
	 * @param username
	 * @param password
	 */
	public EmailManager(String host, boolean authenticate, String username, String password) {
		super();
		JavaMailSenderImpl sender = new JavaMailSenderImpl();
		sender.setHost(host);
		if (authenticate) {
			sender.setUsername(username);
			sender.setPassword(password);
		}
		this.sender = sender;
	}

	/**
	 * @return
	 */
	public MessageSource getMessageSource() {
		return messageSource;
	}

	/**
	 * @param messageSource
	 */
	public void setMessageSource(MessageSource messageSource) {
		this.messageSource = messageSource;
	}

	/**
	 * @return
	 */
	public JavaMailSenderImpl getSender() {
		return sender;
	}

	/**
	 * @param sender
	 */
	public void setSender(JavaMailSenderImpl sender) {
		this.sender = sender;
	}

	/**
	 * @return
	 */
	public String getFrom() {
		return from;
	}

	/**
	 * @param from
	 */
	public void setFrom(String from) {
		this.from = from;
	}

	/**
	 * @param locale
	 * @param userEmail
	 * @return
	 * @throws AddressException
	 * @throws MessagingException
	 */
	public boolean sendAccountCreationEmail(Locale locale, String userEmail) throws AddressException,
			MessagingException {

		String emailTitle = messageSource.getMessage("email.register.title", null, locale);
		String emailPart1 = messageSource.getMessage("email.register.part1", null, locale);
		String emailPart2 = messageSource.getMessage("email.register.part2", null, locale);
		String emailPart3 = messageSource.getMessage("email.register.part3", null, locale);

		MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));
		message.addRecipient(RecipientType.BCC, new InternetAddress(messageBCC1));
		message.addRecipient(RecipientType.BCC, new InternetAddress(messageBCC2));
		MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
		helper.setFrom(from);
		helper.setTo(userEmail);
		helper.setSubject(emailTitle);
		helper.setText("<html><body>" + emailPart1 + "\n<br />\n<br />" + emailPart2 + " " + userEmail
				+ "\n<br />" + emailPart3 + "</body></html>", true);

		// message.setText("my text <img src='cid:myLogo'>", true);
		// message.addInline("myLogo", new ClassPathResource("img/mylogo.gif"));
		// message.addAttachment("myDocument.pdf", new ClassPathResource("doc/myDocument.pdf"));
		// let's include the infamous windows Sample file (this time copied to c:/)
		// message.setText("<html><body><img src='cid:identifier1234'></body></html>");
		// FileSystemResource res = new FileSystemResource(new File("c:/Sample.jpg"));
		// helper.addInline("identifier1234", res);

		sender.send(message);
		return true;
	}

	/**
	 * @param userEmail
	 * @param newPassword
	 * @throws AddressException
	 * @throws MessagingException
	 */
	public boolean sendPasswordResetEmail(Locale locale, String userEmail, String newPassword)
			throws AddressException, MessagingException {
		// MimeMessage message = sender.createMimeMessage();
		// message.setFrom(new InternetAddress(from));
		// MimeMessageHelper helper = new MimeMessageHelper(message);
		//
		// helper.setSubject("Spectral Database: password Reset");
		// helper.setTo(userEmail);
		// helper.setText("Your password has been reset; \n"
		// +
		// "\nthe following password is temporary, change it during your next visit on the Sepctral Database portal\n"
		// + "\nYour new password is : \n" + newPassword);

		String subject = messageSource.getMessage("email.resetpassword.title", null, locale);
		String emailPart1 = messageSource.getMessage("email.resetpassword.part1", null, locale);
		String emailPart2 = messageSource.getMessage("email.resetpassword.part2", null, locale);
		String emailPart3 = messageSource.getMessage("email.resetpassword.part3", null, locale);

		MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));

		MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
		helper.setFrom(from);
		helper.setTo(userEmail);
		helper.setSubject(subject);
		helper.setText("<html><body>" + emailPart1 + " \n<br />" + "\n<br />" + emailPart2 + "<br />"
				+ "\n<br />" + emailPart3 + " \n<br />" + newPassword + "</body></html>", true);

		sender.send(message);
		return true;
	}

	/**
	 * @param userEmail
	 * @param newPassword
	 * @throws AddressException
	 * @throws MessagingException
	 */
	public boolean sendEmail(String userEmail, String messageSubject, String messageConent, boolean html)
			throws AddressException, MessagingException {

		MimeMessage message = sender.createMimeMessage();
		message.setFrom(new InternetAddress(from));

		MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
		helper.setFrom(from);
		helper.setTo(userEmail);
		helper.setSubject(messageSubject);
		helper.setText(messageConent, html);

		sender.send(message);
		return true;
	}

	/**
	 * @return the messageBCC
	 */
	public String getMessageBCC1() {
		return messageBCC1;
	}

	/**
	 * @param messageBCC
	 *            the messageBCC to set
	 */
	public void setMessageBCC1(String messageBCC) {
		this.messageBCC1 = messageBCC;
	}

	/**
	 * @return the messageBCC
	 */
	public String getMessageBCC2() {
		return messageBCC2;
	}

	/**
	 * @param messageBCC
	 *            the messageBCC to set
	 */
	public void setMessageBCC2(String messageBCC) {
		this.messageBCC2 = messageBCC;
	}

}
