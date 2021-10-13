package fr.metabohub.peakforest.utils;

import java.io.Console;
import java.util.Scanner;

import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;

public class UsersTools {
	// cd ~/Workspace/peakforest-webapp/
	// java -cp
	// "peakforest-webapp-efb0d7c9.war:peakforest-webapp-efb0d7c9/WEB-INF/classes/:peakforest-webapp-efb0d7c9/WEB-INF/lib/*"
	// fr.metabohub.peakforest.utils.UsersTools test test

	public static final String RIGHTS_USER = "user";
	public static final String RIGHTS_CURATOR = "curator";
	public static final String RIGHTS_ADMIN = "admin";

	public static void main(String[] args) throws Exception {

		// init var
		String email = null;
		String password = null;
		String rights = null;

		// check arvg
		if (args.length > 0) {
			for (int i = 0; i < args.length; i++) {
				switch (args[i].charAt(0)) {
				case '-':
					if (args[i].length() < 2)
						throw new IllegalArgumentException("Not a valid argument: " + args[i]);
					if (args[i].charAt(1) == '-') {
						if (args[i].length() < 3)
							throw new IllegalArgumentException("Not a valid argument: " + args[i]);
						// --opt
						String param = args[i].substring(2, args[i].length());
						if (param.equalsIgnoreCase("help")) {
							affiUsage();
							return;
						}
						if (args.length - 1 == i)
							throw new IllegalArgumentException("Expected arg after: " + args[i]);
						// System.out.println(param + "=>" + args[i + 1]);
						switch (param.toLowerCase()) {
						case "email":
							email = args[i + 1];
							break;
						case "password":
							password = args[i + 1];
							break;
						case "rights":
							rights = args[i + 1];
							break;
						default:
							// break;
							throw new IllegalArgumentException("Unknown arg: " + args[i]);
						}
						i++;
					} else {
						String param = args[i];
						if (param.equalsIgnoreCase("-h")) {
							affiUsage();
							return;
						}
						if (args.length - 1 == i)
							throw new IllegalArgumentException("Expected arg after: " + args[i]);
						// -opt
						// System.out.println(param + "=>" + args[i + 1]);
						switch (param.toLowerCase()) {
						case "-e":
							email = args[i + 1];
							break;
						case "-p":
							password = args[i + 1];
							break;
						case "-r":
							rights = args[i + 1];
							break;
						default:
							// break;
							throw new IllegalArgumentException("Unknown arg: " + args[i]);
						}
						i++;
					}
					break;
				default:
					break;
				}
			}
		} else {
			// ask user
			final Scanner reader = new Scanner(System.in);
			final Console console = System.console();
			if (console == null) {
				System.err.println("Couldn't get Console instance");
				System.exit(0);
			}
			// email
			while (email == null || email.trim().equals("")) {
				System.out.print("please enter an email: ");
				email = reader.nextLine();
			}
			// password
			while (password == null || password.trim().equals("")) {

				char passwordArray[] = console.readPassword("please enter a password: ");
				password = new String(passwordArray);
			}
			// rights
			while (rights == null || rights.trim().equals("")) {
				System.out.print("please enter rights level [1: user, 2: curator, 3: admin]: ");
				int rightsI = reader.nextInt();
				if (rightsI == 1) {
					rights = "user";
				} else if (rightsI == 2) {
					rights = "curator";
				} else if (rightsI == 3) {
					rights = "admin";
				}
			}
			reader.close();
		}

		if (email != null && password != null && rights != null) {
			if (!UserManagementService.exists(email))
				// create!
				try {
					User newUser = new User();
					newUser.setEmail(email);
					newUser.setLogin(email);
					switch (rights.toLowerCase()) {
					case RIGHTS_ADMIN:
						newUser.setAdmin(true);
					case RIGHTS_CURATOR:
						newUser.setCurator(true);
					default:
						newUser.setConfirmed(true);
						break;
					}
					newUser.setPassword((new StandardPasswordEncoder()).encode(password));
					UserManagementService.create(newUser);
					// log
					System.out.println("add new user @email=" + email + " ");
				} catch (Exception e) {
					e.printStackTrace();
				}
			else {
				// update
				final User existingUser = UserManagementService.read(email);
				// set right
				switch (rights.toLowerCase()) {
				case RIGHTS_ADMIN:
					existingUser.setAdmin(true);
				case RIGHTS_CURATOR:
					existingUser.setCurator(true);
				default:
					existingUser.setConfirmed(true);
					break;
				}
				// set password
				StandardPasswordEncoder encoder = new StandardPasswordEncoder();
				existingUser.setPassword(encoder.encode(password));
				// update
				UserManagementService.update(existingUser);
			}
		} else {
			throw new Exception("Missing data to create new user (its 'email' or 'password' or 'rights')");
		}
		// adios!
		// System.exit(0);
	}

	public static void affiUsage() {
		System.out.println("UsersTools: How to use it! ");
		System.out.println("\tjava -cp \"fullClassPath\" fr.metabohub.peakforest.utils.UsersTools [args] ");
		System.out.println("\t[args] ");
		System.out.println("\tnone: launch script in interactive mode.");
		System.out.println("\t-h|--help: display this help message");
		System.out.println(
				"\t-e|--email: create/overwrite a user wit this login (warning: this script does not check if the email is valid!).");
		System.out.println("\t-p|--password: set the user password.");
		System.out.println("\t-r|--rights: set the user rights (must be \"USER\", \"CURATOR\" or \"ADMIN\").");
	}

}
