role Net::SMTP::Raw;

has $.conn is rw;

method get-response() {
    my $line = $.conn.get;
    my $response = $line;
    while $line.substr(3,1) ne ' ' {
        $line = $.conn.get;
        $response ~= "\r\n"~$line;
    }
    return $response;
}

method send($stuff) {
    $.conn.send($stuff ~ "\r\n");
    return self.get-response;
}

method ehlo($hostname = gethostname()) {
    return self.send("EHLO $hostname");
}

method helo($hostname = gethostname()) {
    return self.send("HELO $hostname");
}

method mail-from($address) {
    return self.send("MAIL FROM:$address");
}

method rcpt-to($address) {
    return self.send("RCPT TO:$address");
}

method data() {
    return self.send("DATA");
}

method payload($mail is copy) {

    # Dot-stuffing!
    # RFC 5321, section 4.5.2:
    # every line that begins with a dot has one additional dot prepended to it.
    my @lines = $mail.split("\r\n");
    for @lines -> $_ is rw {
        if $_.substr(0,1) eq '.' {
            $_ = '.' ~ $_;
        }
    }
    $mail = @lines.join("\r\n");

    if $mail.substr(*-2,2) ne "\r\n" {
        $mail ~= "\r\n";
    }
    return self.send($mail ~ ".");
}

method rset() {
    return self.send("RSET");
}

method quit() {
    return self.send("QUIT");
}
