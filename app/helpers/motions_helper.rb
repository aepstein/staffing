module MotionsHelper
  def link_to_watch_toggle( motion )
    if permitted_to? :watch, motion
      link_to 'Watch', watch_motion_path( motion )
    elsif permitted_to? :unwatch, motion
      link_to 'Unwatch', unwatch_motion_path( motion )
    end
  end
end

